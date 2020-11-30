CREATE TABLE [dbo].[VU_Configuracion] (
    [IdConfiguracion] INT            IDENTITY (1, 1) NOT NULL,
    [Variable]        NVARCHAR (MAX) NULL,
    [Valor]           NVARCHAR (MAX) NULL,
    [Activo]          BIT            NULL,
    CONSTRAINT [PK_VU_Configuracion] PRIMARY KEY CLUSTERED ([IdConfiguracion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

