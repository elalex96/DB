-- =============================================
-- Author:		Pedro Acuña
-- Create date: 14/09/2018
-- Description:	consultar los documentos cargados en petrovendor Tipo Documento (ADM_TipoDocumentosS3 )
--8 Documentos por material Cotizacion/Oferta por Material
--9 Documentos Anexos Cotizacion/Oferta por Material 
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <05-11-2018 >
-- Description:	<Se agrega la fecha y el nombre de cuando y quien subio el documento>
-- =============================================

CREATE PROCEDURE SP_ADM_ConsultaDocumentosS3Petrovendor 
	@IdSolicitudPedido INT
AS
BEGIN
    DECLARE @tablaAux TABLE
    (
        Fila INT IDENTITY,
        TipoDocumento INT,
        IdDocumento INT,
        NombreDoc NVARCHAR(MAX),
        IdSubcontratista INT,
        Descripcion NVARCHAR(MAX),
        NombreUsuario NVARCHAR(150),
        FechaCarga DATETIME
    );

    INSERT INTO @tablaAux
    (
        TipoDocumento,
        IdDocumento,
        NombreDoc,
        IdSubcontratista,
        Descripcion,
		NombreUsuario,
		FechaCarga
    )
    SELECT 8,
           doc.IdDocumentoAnexo,
           doc.Nombre,
           PO.IdSubcontratista,
           CONVERT(NVARCHAR(50), SPD.Cantidad) + ' - ' + m.DescripcionCorta + ' - ' + m.Modelo,
		   u.Nombre,
		   doc.CreadoEl
    FROM MM_DocumentosAnexos doc
		LEFT JOIN dbo.S_Usuario u ON u.IdUsuario = doc.CreadoPor
        INNER JOIN dbo.MM_PeticionOferta PO ON PO.IdPeticionOferta = doc.IdPeticionOferta
        INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle = doc.IdPeticionOfertaDetalle
        INNER JOIN MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
        LEFT JOIN dbo.MM_Material m ON m.IdMaterial = POD.IdMaterial
        LEFT JOIN dbo.MM_SolicitudPedido ped ON ped.IdSolicitudPedido = PO.IdSolicitudPedido
    WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
          AND doc.Activo = 1
          AND ISNULL(ped.IdEstatusEliminado, 0) = 0;

    INSERT INTO @tablaAux
    (
        TipoDocumento,
        IdDocumento,
        NombreDoc,
        IdSubcontratista,
		NombreUsuario,
		FechaCarga
    )
    SELECT 9,
           IdDocAnexoPeticionOferta,
           NomDocumento,
           PO.IdSubcontratista,
		   u.Nombre,
		   CAST(doc.SubidoEl AS DATETIME)
    FROM dbo.MM_DocAnexosPeticionOferta doc
		LEFT JOIN dbo.S_Usuario u ON u.IdUsuario = doc.SubidoPor
        LEFT JOIN dbo.MM_PeticionOferta PO ON PO.IdPeticionOferta = doc.IdPeticionOferta
        LEFT JOIN dbo.MM_SolicitudPedido ped             ON ped.IdSolicitudPedido = PO.IdSolicitudPedido
    WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
          AND ISNULL(Eliminado, 0) = 0
          AND ISNULL(ped.IdEstatusEliminado, 0) = 0;

    SELECT *
    FROM @tablaAux;
END;
