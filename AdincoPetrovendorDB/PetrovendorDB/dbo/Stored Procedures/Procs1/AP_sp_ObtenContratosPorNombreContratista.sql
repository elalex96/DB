CREATE PROCEDURE AP_sp_ObtenContratosPorNombreContratista
	@IdContrato Int,
	@NombreContratista varchar(300)
as
BEGIN
	DECLARE @IdContratista Int;

	--set @IdContratista = (select top 1 MAX(IdContratista) from Adinco..CO_Contratista 
	--		where NombreContratista like '%' + @NombreContratista + '%')

select @IdContratista = IdContratista
FROM Adinco..CO_Contrato 
WHERE IdContrato = @IdContrato

	IF @IdContratista IN (2, 10005, 10006, 10013, 10017, 10022, 10060)
	BEGIN
		select * from Adinco..CO_Contrato 
		where 	IdContrato = @IdContrato
	END
	ELSE
	BEGIN
		select * from Adinco..CO_Contrato 
		where 1 = 2
	END

END
--exec AP_sp_ObtenContratosPorNombreContratista 10041,'Deutsche Erdoel México'