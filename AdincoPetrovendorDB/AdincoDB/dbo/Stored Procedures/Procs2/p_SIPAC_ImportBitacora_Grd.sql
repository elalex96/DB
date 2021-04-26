CREATE proc p_SIPAC_ImportBitacora_Grd
@IdContrato int
as

	select	b.Id,
			b.IdContrato,
			c.NumeroContrato,
			b.NombreArchivo,
			b.FechaCarga,
			b.IdAWSExcel,
			aws.NombreArchivo,
			b.MesReporte,
			b.IdError,
			b.CreadoPor ,
			Error = e.Mensaje,
			ErrorDetalle = e.StackTrace,
			Usuario = u.Usuario
	from [dbo].[SIPAC_ImportBitacora] b
	INNER JOIN CO_Contrato c on c.IdContrato = b.IdContrato
	INNER JOIN AP_Usuario u on u.usuarioId = b.CreadoPor
	LEFT JOIN AP_BitacoraErrores  e on e.IdError = b.IdError
	LEFT JOIN AWS_Documentos aws on aws.AWSDocumentoId = b.IdAWSExcel
	where b.IdContrato = @IdContrato
	order by b.id desc