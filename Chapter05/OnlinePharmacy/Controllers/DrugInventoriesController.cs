using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using OnlinePharmacy.Models;

namespace OnlinePharmacy.Controllers
{
    public class DrugInventoriesController : Controller
    {
        private medicineEntities db = new medicineEntities();

        // GET: DrugInventories
        public ActionResult Index()
        {
            var drugInventories = db.DrugInventories.Include(d => d.Drug);
            return View(drugInventories.ToList());
        }

        // GET: DrugInventories/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            DrugInventory drugInventory = db.DrugInventories.Find(id);
            if (drugInventory == null)
            {
                return HttpNotFound();
            }
            return View(drugInventory);
        }

        // GET: DrugInventories/Create
        public ActionResult Create()
        {
            ViewBag.DrugID = new SelectList(db.Drugs, "DrugID", "Name");
            return View();
        }

        // POST: DrugInventories/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "DrugInventoryID,DrugID,BatchNo,Quantity,PruchaseDate,ManufatureDate,ExpiryDate")] DrugInventory drugInventory)
        {
            if (ModelState.IsValid)
            {
                db.DrugInventories.Add(drugInventory);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.DrugID = new SelectList(db.Drugs, "DrugID", "Name", drugInventory.DrugID);
            return View(drugInventory);
        }

        // GET: DrugInventories/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            DrugInventory drugInventory = db.DrugInventories.Find(id);
            if (drugInventory == null)
            {
                return HttpNotFound();
            }
            ViewBag.DrugID = new SelectList(db.Drugs, "DrugID", "Name", drugInventory.DrugID);
            return View(drugInventory);
        }

        // POST: DrugInventories/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "DrugInventoryID,DrugID,BatchNo,Quantity,PruchaseDate,ManufatureDate,ExpiryDate")] DrugInventory drugInventory)
        {
            if (ModelState.IsValid)
            {
                db.Entry(drugInventory).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.DrugID = new SelectList(db.Drugs, "DrugID", "Name", drugInventory.DrugID);
            return View(drugInventory);
        }

        // GET: DrugInventories/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            DrugInventory drugInventory = db.DrugInventories.Find(id);
            if (drugInventory == null)
            {
                return HttpNotFound();
            }
            return View(drugInventory);
        }

        // POST: DrugInventories/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            DrugInventory drugInventory = db.DrugInventories.Find(id);
            db.DrugInventories.Remove(drugInventory);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
