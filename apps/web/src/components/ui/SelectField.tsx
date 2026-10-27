import type { ReactNode, SelectHTMLAttributes } from "react";

type SelectFieldProps = Omit<SelectHTMLAttributes<HTMLSelectElement>, "id"> & {
  id: string;
  label: string;
  children: ReactNode;
};

export function SelectField({ id, label, children, className = "", ...props }: SelectFieldProps) {
  return <div className="ui-field">
    <label htmlFor={id}>{label}</label>
    <select id={id} className={`ui-select-field ${className}`.trim()} {...props}>{children}</select>
  </div>;
}
