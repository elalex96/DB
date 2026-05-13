create PROCEDURE [dbo].[ReporteSeguimiento] (@IdProveedor INT )
AS
BEGIN

	SELECT 
		SP.IdSolicitudPedido,
		SP.MotivoUrgencia AS Justificacion,
		U.Nombre AS Requisitor,
		SP.FechaAlta,
		AC.NombreAreaContractual AS AreaContractual,
		dbo.FN_Reporte(SP.IdSolicitudPedido) AS Instalacion,
		dbo.FN_Aprobadores(SP.IdSolicitudPedido) AS Aprobador,
		T.Nombre AS EstatusRequisicion,
		UPO.Nombre AS UsuarioSolicitudOferta,
		PO.CreadoEl AS AltaSolicitudOferta,
		PO.FechaFinalizado AS FechaCotizacion,
		PR.RazonSocial AS Proveedor,
		SP.PeticionEnviada,
		PO.Cotizado,
		((CASE 
				WHEN(DATEDIFF(MINUTE, PO.FechaFinalizado, GETDATE())) <= 0 
				THEN 'false' ELSE 'true'
		END)) AS Vencida
	FROM dbo.MM_SolicitudPedido AS SP
		LEFT JOIN dbo.S_Usuario AS U ON SP.IdUsuarioSolicitante = U.IdUsuario
		LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = SP.IdContrato
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
		LEFT JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
		LEFT JOIN dbo.TA_Estatus AS T ON T.IdEstatus = O.IdEstatusOperacion
		LEFT JOIN dbo.MM_PeticionOferta AS PO ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		LEFT JOIN dbo.MM_Oferta AS MO ON MO.IdPeticionOferta = PO.IdPeticionOferta
		LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = PO.IdSubcontratista
		LEFT JOIN dbo.S_Usuario AS UPO ON UPO.IdUsuario = PO.CreadoPor
	WHERE SP.IdProveedor = @IdProveedor
	--WHERE SP.IdSolicitudPedido = 12275

END

		