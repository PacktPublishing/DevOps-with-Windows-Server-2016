
/****** Object:  Database [medicine]    Script Date: 8/6/2016 5:43:13 AM ******/


/****** Object:  Table [dbo].[Drug]    Script Date: 8/6/2016 5:43:13 AM ******/


CREATE TABLE [dbo].[Drug](
	[DrugID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Form] [varchar](50) NOT NULL,
	[Route] [varchar](50) NOT NULL,
	[IsRestricted] [bit] NOT NULL,
	[Purpose] [varchar](200) NULL,
	[Description] [varchar](200) NULL,
	[Rate] [numeric](18, 0) NOT NULL,
 CONSTRAINT [PK_Drug] PRIMARY KEY CLUSTERED 
(
	[DrugID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]



/****** Object:  Table [dbo].[DrugInventory]    Script Date: 8/6/2016 5:43:13 AM ******/


CREATE TABLE [dbo].[DrugInventory](
	[DrugInventoryID] [int] IDENTITY(1,1) NOT NULL,
	[DrugID] [int] NOT NULL,
	[BatchNo] [varchar](50) NOT NULL,
	[Quantity] [int] NOT NULL,
	[PruchaseDate] [date] NOT NULL,
	[ManufatureDate] [date] NOT NULL,
	[ExpiryDate] [date] NOT NULL,
 CONSTRAINT [PK_DrugInventory] PRIMARY KEY CLUSTERED 
(
	[DrugInventoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]



CREATE TABLE [dbo].[SaleItem](
	[SaleItemID] [int] IDENTITY(1,1) NOT NULL,
	[MedicineID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Rate] [numeric](18, 0) NOT NULL,
	[Total] [numeric](18, 0) NOT NULL,
	[SaleID] [int] NOT NULL,
 CONSTRAINT [PK_SaleItem] PRIMARY KEY CLUSTERED 
(
	[SaleItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [dbo].[Sales](
	[SaleID] [int] IDENTITY(1,1) NOT NULL,
	[PatientName] [varchar](50) NULL,
	[DoctorName] [varchar](50) NULL,
	[SaleDate] [date] NOT NULL,
 CONSTRAINT [PK_Sales] PRIMARY KEY CLUSTERED 
(
	[SaleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


SET ANSI_PADDING OFF

ALTER TABLE [dbo].[DrugInventory]  WITH CHECK ADD  CONSTRAINT [FK_DrugInventory_Drug] FOREIGN KEY([DrugID])
REFERENCES [dbo].[Drug] ([DrugID])

ALTER TABLE [dbo].[DrugInventory] CHECK CONSTRAINT [FK_DrugInventory_Drug]

ALTER TABLE [dbo].[SaleItem]  WITH CHECK ADD  CONSTRAINT [FK_SaleItem_Drug] FOREIGN KEY([MedicineID])
REFERENCES [dbo].[Drug] ([DrugID])

ALTER TABLE [dbo].[SaleItem] CHECK CONSTRAINT [FK_SaleItem_Drug]

ALTER TABLE [dbo].[SaleItem]  WITH CHECK ADD  CONSTRAINT [FK_SaleItem_Sales] FOREIGN KEY([SaleID])
REFERENCES [dbo].[Sales] ([SaleID])

ALTER TABLE [dbo].[SaleItem] CHECK CONSTRAINT [FK_SaleItem_Sales]


