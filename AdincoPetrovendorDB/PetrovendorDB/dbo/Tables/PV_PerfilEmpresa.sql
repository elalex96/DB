CREATE TABLE [dbo].[PV_PerfilEmpresa] (
    [IdPerfilEmpresa]        INT      IDENTITY (1, 1) NOT NULL,
    [IdGiroEmpresaria]       INT      NULL,
    [AniosExperiencia]       INT      NULL,
    [IdDocumentoOrganigrama] INT      NULL,
    [IdDocumentoCurriculum]  INT      NULL,
    [CreadoPor]              INT      NULL,
    [CreadoEl]               DATETIME NULL,
    [EditadoPor]             INT      NULL,
    [EditadoEl]              DATETIME NULL,
    [Activo]                 BIT      NULL,
    [IdProveedor]            INT      NULL,
    CONSTRAINT [PK_PV_PerfilEmpresa] PRIMARY KEY CLUSTERED ([IdPerfilEmpresa] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

