import type { ButtonHTMLAttributes, ReactNode } from "react";

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  variant?: "primary" | "secondary" | "danger";
};

export function Button({ variant = "primary", className = "", children, ...props }: ButtonProps) {
  const baseStyle = variant === "primary" ? "submit-button" : "";
  return <button className={`ui-button ui-button-${variant} ${baseStyle} ${className}`.trim()} {...props}>{children}</button>;
}
