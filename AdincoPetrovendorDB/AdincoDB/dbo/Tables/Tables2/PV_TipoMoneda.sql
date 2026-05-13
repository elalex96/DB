CREATE TABLE [dbo].[PV_TipoMoneda] (
    [IdMoneda]        INT            IDENTITY (10000, 1) NOT NULL,
    [TipoMoneda]      VARCHAR (50)   NOT NULL,
    [TipoMonedaCorto] NVARCHAR (MAX) NULL,
    [Eliminado]       BIT            NULL,
    [SerieBanxico]    VARCHAR (50)   NULL,
    CONSTRAINT [PK_Cat_TipoMoneda] PRIMARY KEY CLUSTERED ([IdMoneda] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

