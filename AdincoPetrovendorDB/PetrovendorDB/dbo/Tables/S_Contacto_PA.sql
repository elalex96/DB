CREATE TABLE [dbo].[S_Contacto_PA] (
    [IdContacto]                  INT          IDENTITY (1, 1) NOT NULL,
    [IdTipoContacto]              INT          NULL,
    [Nombres]                     VARCHAR (50) NULL,
    [Apellidos]                   VARCHAR (50) NULL,
    [Email]                       VARCHAR (50) NULL,
    [Telefono]                    VARCHAR (10) NULL,
    [IsPredeterminado]            BIT          NULL,
    [IdContratistaSubContratista] INT          NULL,
    [IsEliminado]                 BIT          NULL,
    [Titulo]                      VARCHAR (50) NULL,
    [Puesto]                      VARCHAR (50) NULL,
    [Celular_VENTAS]              VARCHAR (10) NULL,
    [IdProveedor]                 INT          NULL,
    CONSTRAINT [PK_S_Contacto_PA] PRIMARY KEY CLUSTERED ([IdContacto] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_S_Contacto_PA_PV_ContratistaSubContratista] FOREIGN KEY ([IdContratistaSubContratista]) REFERENCES [dbo].[PV_ContratistaSubContratista] ([IdRelacion]),
    CONSTRAINT [FK_S_Contacto_PA_S_TipoContacto] FOREIGN KEY ([IdTipoContacto]) REFERENCES [dbo].[S_TipoContacto] ([IdTipoContacto])
);

