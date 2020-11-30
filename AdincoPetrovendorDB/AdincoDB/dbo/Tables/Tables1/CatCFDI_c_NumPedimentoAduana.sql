CREATE TABLE [dbo].[CatCFDI_c_NumPedimentoAduana] (
    [IdPAduana]           INT            IDENTITY (1, 1) NOT NULL,
    [c_Aduana]            NVARCHAR (255) NULL,
    [Patente]             NVARCHAR (255) NULL,
    [Ejercicio]           FLOAT (53)     NULL,
    [Cantidad]            FLOAT (53)     NULL,
    [Fechainiciovigencia] DATETIME       NULL,
    [Fechafinvigencia]    NVARCHAR (255) NULL
);

