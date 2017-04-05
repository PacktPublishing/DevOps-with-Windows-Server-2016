using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using OnlinePharmacy.Models;
using System.Web.Routing;

namespace OnlinePharmacy.Controllers
{
    public class DrugsController : Controller
    {
        /* private medicineEntities db = new medicineEntities(); */
        private IDrug _drugObject;
        public DrugsController()
        {
            _drugObject = new DrugRepository();
        }
        public DrugsController(IDrug _drug)
        {
            _drugObject = _drug;
        }
        // GET: Drugs
        public ActionResult Index()
        {
            /* return View(db.Drugs.ToList()); */
            return View("Index",_drugObject.GetAllDrugs());
        }

        // GET: Drugs/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            /* Drug drug = db.Drugs.Find(id); */
            Drug drug = _drugObject.GetDrugDetails(id);
            if (drug == null)
            {
                return HttpNotFound();
            }
            return View("Details",drug);
        }

        // GET: Drugs/Create
        public ActionResult Create()
        {
            return View("Create");
        }

        // POST: Drugs/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "DrugID,Name,Form,Route,IsRestricted,Purpose,Description,Rate")] Drug drug)
        {
            if (ModelState.IsValid)
            {
                /* db.Drugs.Add(drug);
                 db.SaveChanges(); */
                _drugObject.CreateDrug(drug);
                //return RedirectToAction("Index");
                return new RedirectToRouteResult(new RouteValueDictionary(new { action = "Index", controller = "Drugs" }));
            }

            return View("Create",drug);
        }

        // GET: Drugs/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            /* Drug drug = db.Drugs.Find(id); */
            Drug drug = _drugObject.GetDrugDetails(id);
            if (drug == null)
            {
                return HttpNotFound();
            }
            return View("Edit",drug);
        }

        // POST: Drugs/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "DrugID,Name,Form,Route,IsRestricted,Purpose,Description,Rate")] Drug drug)
        {
            if (ModelState.IsValid)
            {
                /*  db.Entry(drug).State = EntityState.Modified;
                  db.SaveChanges(); */
                _drugObject.EditDrug(drug);
                return new RedirectToRouteResult(new RouteValueDictionary(new { action = "Index", controller = "Drugs" }));
            }
            return View("Edit", drug);
        }

        // GET: Drugs/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            /* Drug drug = db.Drugs.Find(id); */
            Drug drug = _drugObject.GetDrugDetails(id);
            if (drug == null)
            {
                return HttpNotFound();
            }
            return View("delete", drug);
        }

        // POST: Drugs/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            /* Drug drug = db.Drugs.Find(id);
             db.Drugs.Remove(drug);
            db.SaveChanges(); */
            Drug drug = _drugObject.GetDrugDetails(id);
            _drugObject.DeleteDrug(drug);
            //return RedirectToAction("Index");
            return new RedirectToRouteResult(new RouteValueDictionary(new { action = "Index", controller = "Drugs" }));


        }
        //protected override void Dispose(bool disposing)
        //{
        //    if (disposing)
        //    {
        //        db.Dispose();
        //    }
        //    base.Dispose(disposing);
        //}
    }
}
