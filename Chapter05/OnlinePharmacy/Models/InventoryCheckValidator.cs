using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace OnlinePharmacy.Models
{
    public class InventoryCheckValidator : ValidationAttribute
    {
        private medicineEntities db = new medicineEntities();
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            if (value != null)
            {
                int saleQuantity = (int)value;

                int? inventory = db.DrugInventories.Where(inv => inv.DrugID == ((SaleItem)validationContext.ObjectInstance).MedicineID).Sum(a => (int?)a.Quantity);
                inventory = inventory ?? 0;
                int? alreadySold = db.SaleItems.Where(m => m.MedicineID == ((SaleItem)validationContext.ObjectInstance).MedicineID).Sum(a => (int?)a.Quantity);
                alreadySold = alreadySold ?? 0;
                if ((inventory.Value - alreadySold.Value) >= saleQuantity)
                {
                    return ValidationResult.Success;
                }
                else
                {
                    if ((inventory.Value - alreadySold.Value) > 0)
                        return new ValidationResult("Not enough Inventory for this Medicine in stock!!.. Maximum quantity can be " + (inventory.Value - alreadySold.Value).ToString());
                    else
                        return new ValidationResult("The stock for this Medicine is 0 !!..");
                }

            }
            return base.IsValid(value, validationContext);
        }
    }
}