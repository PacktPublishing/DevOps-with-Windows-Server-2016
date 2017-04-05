using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using OnlinePharmacy.Controllers;
using OnlinePharmacy.Models;
using System.Web.Mvc;
using System.Collections.Generic;
using System.Linq;

namespace OnlinePharmacy.Tests.Controllers
{
    [TestClass]
    public class DrugControllerTests
    {
        [TestMethod]
        public void IndexViewNameCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            ViewResult result = drug.Index() as ViewResult;
            Assert.AreEqual("Index", result.ViewName);
        }

        [TestMethod]
        public void IndexNotNullCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            ViewResult result = drug.Index() as ViewResult;
            Assert.IsNotNull(result);
        }

        [TestMethod]
        public void DetailsValidDrugIDCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            ViewResult result = drug.Details(1) as ViewResult;
            Assert.AreEqual(1, ((Drug)result.Model).DrugID);
        }

        [TestMethod]
        public void DetailsValidNameCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            ViewResult result = drug.Details(1) as ViewResult;
            Assert.AreEqual("Paracetamol", ((Drug)result.Model).Name);
        }

        [TestMethod]
        public void DetailsNotNullCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            ViewResult result = drug.Details(1) as ViewResult;
            Assert.IsNotNull(result);
        }

        [TestMethod]
        public void IndexObjectsCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            ViewResult result = drug.Index() as ViewResult;
            IEnumerable<Drug> data = (IEnumerable<Drug>)result.Model;
            List<Drug> list = new List<Drug>(mock.GetAllDrugs());
            
            CollectionAssert.Contains(data.ToList(), list[0]);
            CollectionAssert.Contains(data.ToList(), list[1]);
        }

        [TestMethod]
        public void DeleteViewNameCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);

            Drug newDrug = new Drug
            {
                DrugID = 10,
                Description = "A dummy medicine",
                Form = "Capsule",
                Route = "Oral",
                IsRestricted = false,
                Name = "Dummy",
                Purpose = "Does not do anything",
                Rate = 100
            };
            drug.Create(newDrug);
             

            RedirectToRouteResult result = (RedirectToRouteResult)drug.DeleteConfirmed(10);
            Assert.AreEqual("Index", result.RouteValues["action"]);
        }

        [TestMethod]
        public void DeleteNullCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            ViewResult deleteResult = drug.DeleteConfirmed(1) as ViewResult;
            ViewResult result = drug.Details(1) as ViewResult;
            Assert.IsNull(result);
            
        }

        [TestMethod]
        public void CreateNotNullCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            Drug newDrug = new Drug {
                DrugID = 3,
                Description = "Insulin injection",
                Form = "Inject",
                Route = "Injection",
                IsRestricted = false,
                Name = "Insulin",
                Purpose = "Sugar control",
                Rate = 100
            };
            ViewResult createResult = drug.Create(newDrug) as ViewResult;
            ViewResult result = drug.Details(3) as ViewResult;
            Assert.IsNotNull(result);

        }

        [TestMethod]
        public void CreateSuccessCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            Drug newDrug = new Drug
            {
                DrugID = 5,
                Description = "Amoxylin antibiotic",
                Form = "Liquid",
                Route = "Oral",
                IsRestricted = false,
                Name = "Insulin",
                Purpose = "cold and cough",
                Rate = 50
            };
            ViewResult createResult = drug.Create(newDrug) as ViewResult;
            ViewResult result = drug.Details(5) as ViewResult;
            Assert.AreEqual(5, ((Drug)result.Model).DrugID);

        }

        [TestMethod]
        public void CreateViewNameCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            Drug newDrug = new Drug
            {
                DrugID = 4,
                Description = "Penicillin",
                Form = "Inject",
                Route = "Injection",
                IsRestricted = true,
                Name = "Penicillin",
                Purpose = "Antibiotic",
                Rate = 200
            };

            RedirectToRouteResult result = (RedirectToRouteResult)drug.Create(newDrug);
            Assert.AreEqual("Index", result.RouteValues["action"]);

 

        }

        [TestMethod]
        public void EditViewNameCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            Drug newDrug = new Drug
            {
                DrugID = 15,
                Description = "Galvus",
                Form = "tablet",
                Route = "Oral",
                IsRestricted = true,
                Name = "Galvus",
                Purpose = "Diabetes",
                Rate = 150
            };

            drug.Create(newDrug);

            newDrug.Purpose = "controls diabetes and sugar level";

            RedirectToRouteResult result = (RedirectToRouteResult)drug.Edit(newDrug);
            Assert.AreEqual("Index", result.RouteValues["action"]);
        }

        [TestMethod]
        public void EditValidCheck()
        {
            MockDrugRepository mock = new MockDrugRepository();
            DrugsController drug = new DrugsController(mock);
            Drug newDrug = new Drug
            {
                DrugID = 16,
                Description = "Lucentis",
                Form = "tablet",
                Route = "Oral",
                IsRestricted = true,
                Name = "Lucentis",
                Purpose = "Eye Blindness",
                Rate = 150
            };

            drug.Create(newDrug);

            newDrug.Purpose = "Eye Blindness and color blindness";

            drug.Edit(newDrug);
            ViewResult result = drug.Details(16) as ViewResult;
            Assert.AreEqual("Eye Blindness and color blindness", ((Drug)result.Model).Purpose);
        }


    }
}
 