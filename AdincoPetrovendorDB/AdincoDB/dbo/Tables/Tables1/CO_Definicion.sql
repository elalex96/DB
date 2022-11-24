CREATE TABLE [dbo].[CO_Definicion] (
    [IdDefinicion]   INT            IDENTITY (1, 1) NOT NULL,
    [IdTipoContrato] INT            NULL,
    [Termino]        NVARCHAR (MAX) NULL,
    [Definicion]     NVARCHAR (MAX) NULL,
    [CreadoPor]      INT            NULL,
    [IdMarcoLegal]   INT            NULL,
    [Articulo]       VARCHAR (6000) NULL,
    [Inciso]         VARCHAR (6000) NULL,
    [CreadoEn]       DATETIME       NULL,
    CONSTRAINT [PK_CO_Definicion] PRIMARY KEY CLUSTERED ([IdDefinicion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Definicion_CO_TipoContrato] FOREIGN KEY ([IdTipoContrato]) REFERENCES [dbo].[CO_TipoContrato] ([IdTipoContrato])
);

