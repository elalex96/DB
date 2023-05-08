CREATE TABLE [dbo].[CO_ResponsableInformacion] (
    [IdResponsableInformacion] INT            IDENTITY (1, 1) NOT NULL,
    [IdContratista]            INT            NULL,
    [NombreResponsable]        NVARCHAR (MAX) NULL,
    [Telefono]                 NVARCHAR (MAX) NULL,
    [CorreoElectronico]        NVARCHAR (MAX) NULL,
    [CreadoPor]                INT            NULL,
    CONSTRAINT [PK_ResponsableInformacion] PRIMARY KEY CLUSTERED ([IdResponsableInformacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ResponsableInformacion_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo sin abreviaturas de la persona que designe la Empresa como responsable de proporcionar la información a que se refiere el Acuerdo, comenzando por nombre (s), apellido paterno y apellido materno.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_ResponsableInformacion', @level2type = N'COLUMN', @level2name = N'NombreResponsable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número telefónico en el que pueda establecerse comunicación con el responsable de proporcionar la información relacionada con el Acuerdo, incluyendo clave Internacional del país, clave de la ciudad, el número y extensión, que en su caso corresponda.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_ResponsableInformacion', @level2type = N'COLUMN', @level2name = N'Telefono';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Correo electrónico institucional en el que pueda establecerse comunicación con el responsable de proporcionar la información relacionada con el Acuerdo. NO SE ACEPTAN CORREOS PERSONALES. Ejemplo: nombre@dominiodelaEmpresa.com', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_ResponsableInformacion', @level2type = N'COLUMN', @level2name = N'CorreoElectronico';

