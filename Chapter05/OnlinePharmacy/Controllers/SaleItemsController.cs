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
    public class SaleItemsController : Controller
    {
        private medicineEntities db = new medicineEntities();

        // GET: SaleItems
        //   public ActionResult Index()
        //   {
        //       
        //       var saleItems = db.SaleItems.Include(s => s.Drug).Include(s => s.Sale);
        //       return View(saleItems.ToList());
        //   }
        public ActionResult Index(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            //SaleItem saleItem = db.SaleItems.Find(id);
            var saleItem = db.SaleItems.Where(p => p.SaleID == id);
            ViewBag.SaleID = id;
            if (saleItem == null)
            {
                return HttpNotFound();
            }
            return View(saleItem);
        }
        // GET: SaleItems/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            SaleItem saleItem = db.SaleItems.Find(id);

            if (saleItem == null)
            {
                return HttpNotFound();
            }
            return View(saleItem);
        }

        // GET: SaleItems/Create
        public ActionResult Create(int? id)
        {
            ViewBag.MedicineID = new SelectList(db.Drugs, "DrugID", "Name");
            // ViewBag.SaleID = new SelectList(db.Sales, "SaleID", "PatientName");
            ViewBag.SaleID = id;

            return View();
        }

        // POST: SaleItems/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "SaleItemID,MedicineID,Quantity,Rate,Total,SaleID")] SaleItem saleItem)
        {
            if (saleItem.Quantity > 0)
            {
                if (ModelState.IsValid)
                {
                    db.SaleItems.Add(saleItem);
                    db.SaveChanges();
                    return RedirectToAction("Index", new { id = saleItem.SaleID });
                }
            }

            ViewBag.MedicineID = new SelectList(db.Drugs, "DrugID", "Name", saleItem.MedicineID);
            // ViewBag.SaleID = new SelectList(db.Sales, "SaleID", "PatientName", saleItem.SaleID);
            ViewBag.SaleID = saleItem.SaleID;
            return View(saleItem);
        }
        public ActionResult update([Bind(Include = "SaleItemID,MedicineID,Quantity,Rate,Total,SaleID")] SaleItem saleItem)
        {
            decimal inventory = (from m in db.Drugs
                                 where m.DrugID == saleItem.MedicineID
                                 select m.Rate).First();

            ViewBag.MedicineID = new SelectList(db.Drugs, "DrugID", "Name", saleItem.MedicineID);
            // ViewBag.SaleID = new SelectList(db.Sales, "SaleID", "PatientName", saleItem.SaleID);
            ViewBag.SaleID = saleItem.SaleID;
            return View(saleItem);
        }
        // GET: SaleItems/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            SaleItem saleItem = db.SaleItems.Find(id);
            if (saleItem == null)
            {
                return HttpNotFound();
            }
            ViewBag.MedicineID = new SelectList(db.Drugs, "DrugID", "Name", saleItem.MedicineID);
            ViewBag.SaleID = saleItem.SaleID;
            return View(saleItem);
        }

        // POST: SaleItems/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "SaleItemID,MedicineID,Quantity,Rate,Total,SaleID")] SaleItem saleItem)
        {
            if (ModelState.IsValid)
            {
                db.Entry(saleItem).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index", new { id = saleItem.SaleID });
            }
            ViewBag.MedicineID = new SelectList(db.Drugs, "DrugID", "Name", saleItem.MedicineID);
            ViewBag.SaleID = saleItem.SaleID;
            return View(saleItem);
        }

        // GET: SaleItems/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            SaleItem saleItem = db.SaleItems.Find(id);
            if (saleItem == null)
            {
                return HttpNotFound();
            }
            return View(saleItem);
        }

        // POST: SaleItems/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            SaleItem saleItem = db.SaleItems.Find(id);
            db.SaleItems.Remove(saleItem);
            db.SaveChanges();
            return RedirectToAction("Index", new { id = saleItem.SaleID });
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
