using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using OnlinePharmacy.Controllers;
using OnlinePharmacy.Models;

namespace OnlinePharmacy.Tests.Controllers
{
    public class MockDrugRepository : IDrug
    {
        private List<Drug> drugs = new List<Drug>();

        public MockDrugRepository()
        {
            drugs = new List<Drug>
            {
                new Drug {
                    DrugID  = 1,
                    Description = "Paracetamol drug",
                    Form = "tablet",
                    IsRestricted = false,
                    Name = "Paracetamol",
                    Purpose = "Body pain killer",
                    Rate = 10,
                    Route = "Oral"
                   
                },
                new Drug {
                    DrugID  = 2,
                    Description = "Percocet drug",
                    Form = "tablet",
                    IsRestricted = true,
                    Name = "Percocet",
                    Purpose = "Body pain killer",
                    Rate = 20,
                    Route = "Oral"

                }
            };
        }

        public void CreateDrug(Drug newDrug)
        {
            drugs.Add(newDrug);
        }

        public void DeleteDrug(Drug oldDrug)
        {
            drugs.Remove(oldDrug);
        }

        public void EditDrug(Drug oldDrug)
        {
            var drug = drugs.Where(d => d.DrugID == oldDrug.DrugID).FirstOrDefault();
            drugs.Remove(drug);
            drugs.Add(oldDrug);
        }

        public IEnumerable<Drug> GetAllDrugs()
        {
            return drugs;
        }

        public Drug GetDrugDetails(int? id)
        {
            return drugs.SingleOrDefault(d => d.DrugID == id);
        }
    }
}
