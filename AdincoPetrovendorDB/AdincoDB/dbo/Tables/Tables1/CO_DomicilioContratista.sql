CREATE TABLE [dbo].[CO_DomicilioContratista] (
    [IdDomicilio]       INT            IDENTITY (1, 1) NOT NULL,
    [IdContratista]     INT            NOT NULL,
    [Calle]             NVARCHAR (MAX) NULL,
    [CodigoPostal]      NVARCHAR (MAX) NULL,
    [Colonia]           NVARCHAR (MAX) NULL,
    [Numero]            NVARCHAR (MAX) NULL,
    [Piso]              NVARCHAR (MAX) NULL,
    [EntidadFederativa] NVARCHAR (MAX) NULL,
    [Municipio]         NVARCHAR (MAX) NULL,
    [CreadoPor]         INT            NULL,
    CONSTRAINT [PK_DomicilioContratista] PRIMARY KEY CLUSTERED ([IdDomicilio] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DomicilioContratista_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo de la calle del domicilio que señale la Empresa para oír y recibir notificaciones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_DomicilioContratista', @level2type = N'COLUMN', @level2name = N'Calle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número completo a cinco dígitos del código postal del domicilio que señale la Empresa para oír y recibir notificaciones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_DomicilioContratista', @level2type = N'COLUMN', @level2name = N'CodigoPostal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo de la colonia que señale la Empresa para oír y recibir notificaciones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_DomicilioContratista', @level2type = N'COLUMN', @level2name = N'Colonia';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número exterior, y en su caso el número interior o el número del despacho que señale la Empresa para oír y recibir notificaciones. Deberán ser separados por guiones. Ejemplo 76-104', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_DomicilioContratista', @level2type = N'COLUMN', @level2name = N'Numero';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Señalar el piso en el que se encuentra el área que señale la Empresa para oír y recibir notificaciones, en caso de que no aplique dejar en blanco el recuadro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_DomicilioContratista', @level2type = N'COLUMN', @level2name = N'Piso';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Seleccione la entidad federativa donde se encuentra el domicilio que señale la Empresa para oír y recibir notificaciones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_DomicilioContratista', @level2type = N'COLUMN', @level2name = N'EntidadFederativa';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo del municipio o delegación política del domicilio que señale la Empresa para oír y recibir notificaciones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_DomicilioContratista', @level2type = N'COLUMN', @level2name = N'Municipio';

