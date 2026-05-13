CREATE TABLE [dbo].[Sanciones] (
    [MarcoLegal]      VARCHAR (6000) NULL,
    [Articulo]        VARCHAR (6000) NULL,
    [Titulo]          VARCHAR (6000) NULL,
    [Capitulo]        VARCHAR (6000) NULL,
    [Sancionador]     VARCHAR (6000) NULL,
    [TipoInfraccion]  VARCHAR (6000) NULL,
    [Veces_SM_Minimo] FLOAT (53)     NULL,
    [Veces_SM_Maximo] FLOAT (53)     NULL,
    [IdMarcoLegal]    INT            NULL,
    [IdSancionador]   INT            NULL
);

