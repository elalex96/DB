CREATE TABLE [dbo].[CO_RepresentanteLegal] (
    [IdRepresentanteLegal]                INT            IDENTITY (1, 1) NOT NULL,
    [IdContratista]                       INT            NOT NULL,
    [Nombre]                              NVARCHAR (MAX) NULL,
    [RFC]                                 NVARCHAR (MAX) NULL,
    [IdentificacionOficial]               NVARCHAR (MAX) NULL,
    [Telefono]                            NVARCHAR (MAX) NULL,
    [CorreoElectronico]                   NVARCHAR (MAX) NULL,
    [InstrumentoAcreditacionPersonalidad] NVARCHAR (MAX) NULL,
    [InstrumentoAcreditacionFacultades]   NVARCHAR (MAX) NULL,
    [CreadoPor]                           INT            NULL,
    CONSTRAINT [PK_RepresentanteLegal] PRIMARY KEY CLUSTERED ([IdRepresentanteLegal] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_RepresentanteLegal_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del Representante Legal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_RepresentanteLegal', @level2type = N'COLUMN', @level2name = N'IdRepresentanteLegal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo sin abreviaturas del representante legal de la Empresa, comenzando por nombre (s), apellido paterno y apellido materno. Mismo que deberá coincidir con el asentado en la Identificación Oficial que exhiba.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_RepresentanteLegal', @level2type = N'COLUMN', @level2name = N'Nombre';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro Federal de Contribuyentes del representante legal. Deberá de ser capturado completo, separando con un guion la homoclave. Deberá coincidir con lo asentado en el documento expedido por el SAT para tal fin. Ejemplo: DIMJ750614-LS0', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_RepresentanteLegal', @level2type = N'COLUMN', @level2name = N'RFC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la identificación oficial vigente que presente el representante legal de la Empresa. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_RepresentanteLegal', @level2type = N'COLUMN', @level2name = N'IdentificacionOficial';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número telefónico en el que pueda establecerse comunicación con el representante legal de la Empresa, incluyendo clave Internacional del país, clave de la ciudad, el número y extensión, que en su caso corresponda.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_RepresentanteLegal', @level2type = N'COLUMN', @level2name = N'Telefono';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Correo electrónico institucional en el que pueda establecerse comunicación con el representante legal. NO SE ACEPTAN CORREOS PERSONALES. Ejemplo: nombre@dominiodelaEmpresa.com', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_RepresentanteLegal', @level2type = N'COLUMN', @level2name = N'CorreoElectronico';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'El número del instrumento público en el que conste el poder otorgado al representante legal de la Empresa, el nombre, número y circunscripción del fedatario público que la otorgó.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_RepresentanteLegal', @level2type = N'COLUMN', @level2name = N'InstrumentoAcreditacionPersonalidad';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número del instrumento público en el que conste la facultad del otorgante de otorgar poderes, el nombre, número y circunscripción del fedatario público que la formalizó.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_RepresentanteLegal', @level2type = N'COLUMN', @level2name = N'InstrumentoAcreditacionFacultades';

