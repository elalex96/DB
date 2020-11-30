CREATE TABLE [dbo].[PV_MetodoPago] (
    [idMetodoPago] INT           IDENTITY (1, 1) NOT NULL,
    [MetodoPago]   VARCHAR (MAX) NULL,
    [Orden]        INT           NULL,
    [C_FormaPago]  NVARCHAR (50) NULL,
    CONSTRAINT [PK_PV_MetodoPago] PRIMARY KEY CLUSTERED ([idMetodoPago] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

