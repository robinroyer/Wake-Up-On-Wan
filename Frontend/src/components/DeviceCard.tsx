import { Monitor, Power } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface DeviceCardProps {
  name: string;
  status: boolean | null;
  onWake?: () => void;
  delay?: number;
}

const DeviceCard = ({ name, status, onWake, delay = 0 }: DeviceCardProps) => {
  if (status === null) {
    return (
      <div 
        className="glass-card p-6 min-h-[200px] flex items-center justify-center opacity-0 animate-fade-in"
        style={{ animationDelay: `${delay}ms` }}
      >
        <div className="flex flex-col items-center gap-3 text-muted-foreground/40">
          <div className="w-12 h-1 bg-muted-foreground/20 rounded-full" />
          <div className="w-8 h-1 bg-muted-foreground/20 rounded-full" />
        </div>
      </div>
    );
  }

  const isActive = status;

  return (
    <div 
      className={cn(
        "glass-card-hover p-6 min-h-[200px] flex flex-col items-center justify-between opacity-0 animate-fade-in",
        isActive && "border-primary/30"
      )}
      style={{ animationDelay: `${delay}ms` }}
    >
      {/* Status indicator */}
      <div className="absolute top-4 right-4">
        <div className={cn(
          "w-2.5 h-2.5 rounded-full",
          isActive ? "bg-success animate-glow-pulse" : "bg-destructive/60"
        )} />
      </div>

      {/* Icon */}
      <div className={cn(
        "relative mt-4",
        isActive && "animate-float"
      )}>
        <div className={cn(
          "w-16 h-16 rounded-2xl flex items-center justify-center",
          isActive 
            ? "bg-primary/20 text-primary" 
            : "bg-muted/50 text-muted-foreground/60"
        )}>
          <Monitor className="w-8 h-8" />
        </div>
        {isActive && (
          <div className="absolute inset-0 w-16 h-16 rounded-2xl bg-primary/20 blur-xl animate-glow-pulse" />
        )}
      </div>

      {/* Name */}
      <div className="text-center mt-4">
        {!isActive && (
          <span className="text-xs text-destructive/80 font-medium">[Deactivated]</span>
        )}
        <h3 className={cn(
          "font-medium text-sm",
          isActive ? "text-foreground" : "text-muted-foreground"
        )}>
          {name}
        </h3>
      </div>

      {/* Wake Button */}
      <Button
        onClick={onWake}
        disabled={!isActive}
        className={cn(
          "mt-4 gap-2 transition-all duration-300",
          isActive 
            ? "gradient-button hover:opacity-90 hover:scale-105 shadow-lg shadow-primary/20" 
            : "bg-muted text-muted-foreground cursor-not-allowed"
        )}
        size="sm"
      >
        <Power className="w-4 h-4" />
        WAKE ME UP
      </Button>
    </div>
  );
};

export default DeviceCard;
