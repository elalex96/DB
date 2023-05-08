CREATE TABLE [dbo].[CatCFDI_c_Moneda] (
    [IdcMoneda]            INT            IDENTITY (1, 1) NOT NULL,
    [c_Moneda]             NVARCHAR (255) NULL,
    [Descripcion]          NVARCHAR (255) NULL,
    [Decimales]            NVARCHAR (255) NULL,
    [Porcentajevariacion_] NVARCHAR (255) NULL,
    [Fechainiciovigencia]  NVARCHAR (255) NULL,
    [Fechafinvigencia]     NVARCHAR (255) NULL
);

