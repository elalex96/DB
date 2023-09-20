
CREATE TABLE [dbo].[AP_Preferencias] (
  [Id] int IDENTITY (1, 1) NOT NULL,
  [Nombre] varchar(250) NOT NULL,
  [Descripcion] varchar(max) NULL,
  [EsDeUsuario] bit NOT NULL,
  [EsDeProveedor] bit NOT NULL,
  [EsDeContrato] bit NOT NULL,
  [RequiereValor] bit NOT NULL,
  [Activo] bit NOT NULL,
  [CreadoEl]      DATETIME  NOT NULL,
  [CreadoPor]     INT NULL,
  [ModificadoPor]    INT NULL,
  [ModificadoEl]   DATETIME  NULL,
  CONSTRAINT [PK_AP_Preferencias] PRIMARY KEY CLUSTERED ([Id] ASC)
)