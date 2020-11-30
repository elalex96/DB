CREATE TABLE [dbo].[CO_TipoContrato] (
    [IdTipoContrato]    INT            IDENTITY (1, 1) NOT NULL,
    [TipoContratoCorto] NVARCHAR (MAX) NULL,
    [TipoContrato]      NVARCHAR (MAX) NULL,
    [CreadoPor]         INT            NULL,
    CONSTRAINT [PK_CO_TipoContrato] PRIMARY KEY CLUSTERED ([IdTipoContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

