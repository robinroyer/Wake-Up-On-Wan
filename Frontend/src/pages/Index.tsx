import { Wifi } from "lucide-react";
import DeviceCard from "@/components/DeviceCard";
import { toast } from "@/hooks/use-toast";
import { useState, useEffect } from 'react';


const Index = () => {

  const placeholderDevices = [
    { id: 101, name: "" as const, prettyName: "", isActive: null },
    { id: 102, name: "" as const, prettyName: "", isActive: null },
    { id: 103, name: "" as const, prettyName: "", isActive: null },
    { id: 104, name: "" as const, prettyName: "", isActive: null },
    { id: 105, name: "" as const, prettyName: "", isActive: null },
  ];
  
  const [apiDevices, setServers] = useState([]);  
  useEffect(() => {fetchServers();}, []);
  const fetchServers = async () => {
    try {
      const response = await fetch(`api/servers`);
      if (!response.ok) {
        throw new Error('Failed to fetch servers');
      }
      const data = await response.json();
      setServers(data);
    } catch (err) {
      console.error('Error fetching servers:', err);
    }
  };
  
  const wakeUpServer = async (serverName) => {
      try {
        const response = await fetch(
          `api/servers/${encodeURIComponent(serverName)}/wake`,
          {
            method: 'POST',
          }
        );

        if (!response.ok) {
          throw new Error('Failed to wake server');
        }

        await response.json();
      } catch (err) {
        alert(`Failed to wake ${serverName}. Please try again.`);
        console.error('Error waking server:', err);
      }
    };


  const handleWake = (devicePrettyName: string, deviceName: string) => {
    wakeUpServer(deviceName);
    toast({
      title: "Wake signal sent!",
      description: `Waking up ${devicePrettyName}...`,
    });
  };

  return (
    <div className="min-h-screen p-6 md:p-12">
      {/* Background decorations */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/5 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-accent/5 rounded-full blur-3xl" />
      </div>

      <div className="relative max-w-6xl mx-auto">
        {/* Header */}
        <header className="text-center mb-12 opacity-0 animate-fade-in">
          <div className="inline-flex items-center gap-3 mb-4">
            <div className="p-3 rounded-2xl bg-primary/10 border border-primary/20">
              <Wifi className="w-8 h-8 text-primary" />
            </div>
          </div>
          <h1 className="text-4xl md:text-5xl font-bold gradient-text mb-3">
            Wake up on Wan
          </h1>
          <p className="text-muted-foreground text-lg">
            Remotely power on your devices from anywhere
          </p>
        </header>

        {/* Device Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 xl:grid-cols-5 gap-4">
          {apiDevices.map((device, index) => (
            <DeviceCard
              key={device.id}
              name={device.prettyName}
              status={device.isActive}
              onWake={() => handleWake(device.prettyName, device.name)}
              delay={100 + index * 50}
            />
          ))}
          
          {placeholderDevices.map((device, index) => (
            <DeviceCard
              key={device.id}
              name={device.prettyName}
              status={device.isActive}
              onWake={() => handleWake(device.prettyName, device.name)}
              delay={100 + index * 50}
            />
          ))}
        </div>

        {/* Footer */}
        <footer className="text-center mt-16 text-muted-foreground/60 text-sm opacity-0 animate-fade-in" style={{ animationDelay: "600ms" }}>
          <p>Powered by Wake-on-LAN technology</p>
        </footer>
      </div>
    </div>
  );
};

export default Index;
