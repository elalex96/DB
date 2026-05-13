CREATE TABLE [dbo].[CatCFDI_c_Aduana] (
    [IdAduana]            INT            IDENTITY (1, 1) NOT NULL,
    [c_Aduana]            NVARCHAR (255) NULL,
    [Descripcion]         NVARCHAR (255) NULL,
    [Fechainiciovigencia] DATETIME       NULL,
    [Fechafinvigencia]    FLOAT (53)     NULL
);

