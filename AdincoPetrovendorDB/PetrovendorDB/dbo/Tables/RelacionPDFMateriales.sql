CREATE TABLE [dbo].[RelacionPDFMateriales] (
    [IdDocumento]             INT            NOT NULL,
    [NombreArchivo]           NVARCHAR (100) NULL,
    [SolicitudCotizacion]     INT            NOT NULL,
    [IdPeticionOfertaDetalle] INT            NOT NULL
);

