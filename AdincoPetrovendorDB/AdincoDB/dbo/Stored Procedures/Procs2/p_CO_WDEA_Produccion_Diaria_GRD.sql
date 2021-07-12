

-- p_CO_WDEA_Produccion_Diaria_GRD 170
Create proc p_CO_WDEA_Produccion_Diaria_GRD
@IdContrato INT
AS
BEGIN

	SELECT  Id,
			A.IdContrato,
			Contrato = C.NumeroContrato,
			IdAWS,
			Fecha,
			AceiteBrutoOG2_Balance,
			AceiteBrutoOG5_Balance,
			AceiteBrutoTotal_Balance,
			AceiteNetoOG2_Balance,
			AceiteNetoOG5_Balance,
			AceiteNetoTotal_Balance,
			CDeAguaOG2_Balance,
			CDeAguaOG5_Balance,
			CDeAguaTotal_Balance,
			GasFormOG2_Balance,
			GasFormOG5_Balance,
			GasFormTotal_Balance,
			GasInyTotalOG2_Balance,
			GasInyTotalOG5_Balance,
			GasInyTotal_Balance,
			GasInySecoOG2_Balance,
			GasInySecoOG5_Balance,
			GasInySecoTotal_Balance,
			GasInyHumedoOG2_Balance,
			GasInyHumedoOG5_Balance,
			GasInyHumedoTotal_Balance,
			AceiteBrutoOG2_PEP,
			AceiteBrutoOG5_PEP,
			AceiteBrutoTotal_PEP,
			AceiteNetoOG2_PEP,
			AceiteNetoOG5_PEP,
			AceiteNetoTotal_PEP,
			CDeAguaOG2_PEP,
			CDeAguaOG5_PEP,
			CDeAguaTotal_PEP,
			GasFormOG2_PEP,
			GasFormOG5_PEP,
			GasFormTotal_PEP,
			GasInyTotalOG2_PEP,
			GasInyTotalOG5_PEP,
			GasInyTotal_PEP,
			GasInySecoOG2_PEP,
			GasInySecoOG5_PEP,
			GasInySecoTotal_PEP,
			GasInyHumedoOG2_PEP,
			GasInyHumedoOG5_PEP,
			GasInyHumedoTotal_PEP,
			Actualizado,
			A.CreadoPor,
			a.CreadoEl,
			Usuario = U.Usuario,
			NombreArchivo = AWS.NombreArchivo,
			A.Error,
			A.Alerta,
			A.Observaciones
	FROM [CO_WDEA_Produccion_Diaria] A
	INNER JOIN AP_Usuario U on U.UsuarioID = A.CreadoPor
	INNER JOIN CO_Contrato C ON C.IdContrato = A.IdContrato
	LEFT JOIN AWS_Documentos AWS ON AWS.AWSDocumentoId = A.IdAWS
	WHERE A.IdContrato = @IdContrato
	ORDER BY A.Id DESC

END