CREATE TABLE [dbo].[VU_MonedaXML] (
    [IdMonedaXML]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreMonedaXML] NVARCHAR (MAX) NULL,
    [IdMoneda]        INT            NULL,
    CONSTRAINT [PK_MonedasXML] PRIMARY KEY CLUSTERED ([IdMonedaXML] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_VU_MonedaXML_PV_TipoMoneda] FOREIGN KEY ([IdMoneda]) REFERENCES [dbo].[PV_TipoMoneda] ([IdMoneda])
);

