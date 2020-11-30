CREATE TABLE [dbo].[PV_MetodoPago] (
    [idMetodoPago] INT           IDENTITY (1, 1) NOT NULL,
    [MetodoPago]   VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_PV_MetodoPago] PRIMARY KEY CLUSTERED ([idMetodoPago] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

