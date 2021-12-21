
CREATE proc p_CO_SAP_PO_Enable
@pIdContratista int,
@pPO varchar(max),
@pError varchar(250) out
as

	set @pError = ''
	BEGIN TRY

	BEGIN TRAN

	SELECT PO = splitdata
	into #tmpPO
	FROM [dbo].[fnSplitString](@pPO,',')


	UPDATE CO_SAPPO  
	SET POActivo = 0,  
	  CancaladoEl = case when CancaladoEl is null then getdate() else CancaladoEl end  
	FROM CO_SAPPO po  
	inner join CO_Contrato c on c.IdContrato = po.IdContrato  
	LEFT JOIN #tmpPO TPO ON TPO.PO = PO.SAPPONumber
	where c.IdContratista = @pIdContratista AND
	TPO.PO IS NULL


	update CO_SAPPO
	set POActivo = 1,
		CancaladoPor = null,
		CancaladoEl = null
	from CO_SAPPO po
	inner join CO_Contrato c on c.IdContrato = po.IdContrato
	LEFT JOIN #tmpPO TPO ON TPO.PO = PO.SAPPONumber
	where c.IdContratista = @pIdContratista and
	po.SAPPONumber = @pPO AND
	TPO.PO IS NOT NULL

	COMMIT TRAN

	END TRY
	BEGIN CATCH
		SET @pError = ERROR_MESSAGE()
		ROLLBACK TRAN
		
	END CATCH



