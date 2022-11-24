CREATE TABLE [dbo].[CO_Contratista] (
    [IdContratista]       INT            IDENTITY (10000, 1) NOT NULL,
    [NombreContratista]   NVARCHAR (MAX) NOT NULL,
    [Representante]       NVARCHAR (MAX) NULL,
    [PuestoRepresentante] NVARCHAR (MAX) NULL,
    [RazonSocial]         NVARCHAR (MAX) NULL,
    [Calle]               NVARCHAR (MAX) NULL,
    [Numero]              NVARCHAR (MAX) NULL,
    [Colonia]             NVARCHAR (MAX) NULL,
    [Municipio]           NVARCHAR (MAX) NULL,
    [Entidad]             NVARCHAR (MAX) NULL,
    [CodigoPostal]        NVARCHAR (MAX) NULL,
    [Pais]                NVARCHAR (MAX) NULL,
    [RFC]                 NVARCHAR (MAX) NULL,
    [CorreoElectronico]   NVARCHAR (MAX) NULL,
    [Telefono]            NVARCHAR (MAX) NULL,
    [PaginaWeb]           NVARCHAR (MAX) NULL,
    [DocumentoLegal]      NVARCHAR (MAX) NULL,
    [IDSIPAC]             NVARCHAR (MAX) NULL,
    [CreadoPor]           INT            NULL,
    [LogoHTML]            VARCHAR (MAX)  NULL,
    [IdProveedor]         INT            NULL,
    [Logo]                IMAGE          NULL,
    [DefaultPage]         VARCHAR (100)  NULL,
    [IdRuta]              INT            NULL,
    [Abreviatura]         VARCHAR (7)    NULL,
    [ContratistaFicticio] BIT            CONSTRAINT [DF_CO_Contratista_ContratistaFicticio] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Contratistas] PRIMARY KEY CLUSTERED ([IdContratista] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Contratista_PV_Subcontratista] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[PV_Subcontratista] ([IdSubcontratista])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre Corto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'NombreContratista';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo de la Empresa a la que se le otorgó la Asignación, Contrato o Permiso, tal como aparece en su Acta Constitutiva ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'RazonSocial';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo de la calle en que se ubica el domicilio fiscal de la Empresa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'Calle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número exterior de la calle en que se ubica el domicilio fiscal de la Empresa y el número interior en caso de que exista.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'Numero';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo de la colonia en la que se ubica el domicilio fiscal de la Empresa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'Colonia';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo del municipio o delegación política en la que se encuentra el domicilio fiscal de la Empresa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'Municipio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo de la entidad federativa en la que se encuentre el domicilio fiscal de la Empresa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'Entidad';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número completo del Código Postal del domicilio en el que se encuentre el domicilio fiscal de la Empresa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'CodigoPostal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del país en el que se encuentra ubicada el domicilio fiscal de la Empresa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'Pais';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro Federal de Contribuyentes completo de la Empresa, separando con un guion la homoclave. Deberá coincidir con lo asentado en el documento expedido por el SAT para tal fin.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'RFC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Correo electrónico institucional de la Empresa, mismo que podrá ser el medio de contacto electrónico con la Secretaría. NO SE ACEPTAN CORREOS PERSONALES.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'CorreoElectronico';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número telefónico completo de personal de la Empresa que pueda proporcionar información a la Secretaría, sobre la información a que se refiere el Acuerdo y demás disposiciones jurídicas aplicables, el cual deberá incluir clave internacional del país, clave de la ciudad, el número y extensión en caso de que exista. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'Telefono';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección electrónica de la página de internet de la Empresa. Ejemplo: www.paginaEmpresa.com', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'PaginaWeb';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'El número del instrumento público en el que conste la fecha de constitución de la Empresa, el nombre, número y circunscripción del fedatario público que la otorgó y los datos de inscripción en el Registro Público de la Propiedad y Comercio o su equivalente. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contratista', @level2type = N'COLUMN', @level2name = N'DocumentoLegal';

