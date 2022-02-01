create proc p_CO_SAP_ImportBitacora_GRD
@pIdContrato INT
as

	SELECT B.Id,
		B.IdContrato,
		B.Inicio,
		B.Fin,
		B.TieneError,
		B.IdNotificacion,
		B.CreadoEl,
		B.CreadoPor,
		B.NotificacionEnviada,		
		BD.Id,
		BD.IdImportBitacora,
		BD.NombreArchivo,
		BD.Error,
		TieneError2= BD.TieneError
		
	FROM CO_SAP_ImportBitacora B
	LEFT JOIN CO_SAP_ImportBitacora_Detalle BD ON BD.IdImportBitacora = B.Id
	WHERE B.IdContrato = @pIdContrato
	ORDER BY B.CreadoEl desc