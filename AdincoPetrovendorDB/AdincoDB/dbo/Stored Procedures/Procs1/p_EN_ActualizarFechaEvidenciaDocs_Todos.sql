CREATE PROCEDURE p_EN_ActualizarFechaEvidenciaDocs_Todos
@idInstanciaEntregable Int ,
@fechaRealEvidencia datetime = null
as 
begin
--SE CREA TABLA TEMPORAL DE LOS IDES
	CREATE TABLE #Ids
	(Id INT)
--SE AGREGAN LOS IDS DE DOCUMENTOS DE LA INSTANCIA 
	select * from #Ids
	Insert Into #Ids
	SELECT  ID	= DocumentoEntregableId
	  FROM	EN_EntregableDocumento DOC

	  JOIN	EN_ContratoEntregable CE
			ON DOC.idContratoEntregable  =	CE.IdContratoEntregable

	  LEFT JOIN	EN_EntregableRelacion	REL
			ON	DOC.DocumentoEntregableId	=	REL.DocumentoEntregableHijoId
	
	  LEFT JOIN AP_Usuario U
			ON DOC.CreadoPor	=	U.UsuarioID

	 WHERE     
				DOC.Activo	=	1
	   AND      DOC.idTipoArchivo	=	10000
	   AND      DOC.idInstanciaEntregable	=	@idInstanciaEntregable 
--SE ACTUALIZAN LOS REGISTROS
		UPDATE EN_EntregableDocumento
		SET FechaRealEvidencia = @fechaRealEvidencia
		WHERE DocumentoEntregableId in (SELECT Id from #Ids)
--SE SELECCIONAN LOS REGISTROS
	SELECT * FROM EN_EntregableDocumento 
	WHERE DocumentoEntregableId in (SELECT Id from #Ids)
end