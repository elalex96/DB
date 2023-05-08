--Created by: DANIEL MORENO
--Created at : 04/11/2021

--Usage: Get a bill and add more than one with relationship to that
CREATE PROCEDURE [dbo].[SP_FI_RelacionPedimento_INS]
    @IdFacturaPadre INT,
    @IdPedimentoHijo INT ,
	@CreadoPor INT
AS   
    SET NOCOUNT ON;  

	IF NOT EXISTS (
		SELECT 1
		FROM FI_RelacionPedimento
		WHERE IdFacturaPadre = @IdFacturaPadre AND
		IdPedimentoHijo = @IdPedimentoHijo
	)
	BEGIN
		insert into FI_RelacionPedimento
		(IdFacturaPadre,IdPedimentoHijo,CreadoPor,CreadoEl) 
		values (@IdFacturaPadre,@IdPedimentoHijo,@CreadoPor,GETDATE());
	END

