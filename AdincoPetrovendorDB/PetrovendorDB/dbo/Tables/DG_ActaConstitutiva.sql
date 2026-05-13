CREATE TABLE [dbo].[DG_ActaConstitutiva] (
    [IdActaConstitutiva]   INT            IDENTITY (1, 1) NOT NULL,
    [NoActaConstitutiva]   NVARCHAR (150) NULL,
    [Fecha]                DATE           NULL,
    [Nombre]               NVARCHAR (50)  NULL,
    [NoNotario]            NVARCHAR (150) NULL,
    [LugarNotarioPublico]  NVARCHAR (150) NULL,
    [IdProveedor]          INT            NULL,
    [IsEliminado]          BIT            NULL,
    [IsActivo]             BIT            NULL,
    [CreadoPor]            INT            NULL,
    [CreadoEn]             DATETIME       NULL,
    [ModificadoPor]        INT            NULL,
    [ModificadoEn]         DATETIME       NULL,
    [RPPC]                 NVARCHAR (10)  NULL,
    [NombreNotarioPublico] NVARCHAR (350) NULL,
    CONSTRAINT [PK_DG_ActaConstitutiva] PRIMARY KEY CLUSTERED ([IdActaConstitutiva] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DG_ActaConstitutiva_S_Proveedor1] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_DG_ActaConstitutiva_S_Usuario1] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    CONSTRAINT [FK_DG_ActaConstitutiva_S_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

