using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace OnlinePharmacy.Models
{
    public interface IDrug
    {
        IEnumerable<Drug> GetAllDrugs();

        void CreateDrug(Drug newDrug);

        void EditDrug(Drug oldDrug);

        void DeleteDrug(Drug oldDrug);

        Drug GetDrugDetails(int? id);
    }

    public class DrugRepository : IDrug
    {
        private medicineEntities db = new medicineEntities();

        public void CreateDrug(Drug newDrug)
        {
            db.Drugs.Add(newDrug);
            db.SaveChanges();

        }

        public void DeleteDrug(Drug oldDrug)
        {
            db.Drugs.Remove(oldDrug);
            db.SaveChanges();
        }

        public void EditDrug(Drug oldDrug)
        {
            db.Entry(oldDrug).State = EntityState.Modified;
            db.SaveChanges();
        }

        public IEnumerable<Drug> GetAllDrugs()
        {
            return db.Drugs.ToList();
        }

        public Drug GetDrugDetails(int? id)
        {
            Drug drug = db.Drugs.Find(id);
            return drug;
        }


    }
}