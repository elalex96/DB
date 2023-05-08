CREATE PROCEDURE [dbo].[sp_PR_CalcularDiferidaAyer] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
-- =============================================
-- Author:		Miguel
-- Create date: 5-07-2013
-- Description:	Calcular Diferida
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @Fecha as date 
    declare @inicio as date
declare @fin as date
--delete ParoDetalle where cast( Inicio as date) =  cast (  @Fecha as date)

select @Fecha = GETDATE()
select @inicio =@Fecha
select @fin =  @Fecha

while @inicio <= @fin
begin
	exec sp_PR_alocarproduccion  1, @inicio, 1 , 'Sistema'

	select  @inicio = DATEADD(day,1,@inicio)
	print @inicio
	
end

UPDATE    PR_ParoDetalle
SET              ProduccionDiferidaB = PR_ParoDetalle.Duracion * (PR_ControlPozo.ProduccionBruta  / 1440),  ProduccionDiferida = PR_ParoDetalle.Duracion * (PR_ControlPozo.ProduccionNeta  / 1440)
FROM         PR_ParoDetalle INNER JOIN
                      PR_ProdDiariaPozo ON PR_ParoDetalle.ProdDiaria = PR_ProdDiariaPozo.ProdDiaria INNER JOIN
                      PR_ControlPozo ON PR_ProdDiariaPozo.ControlUtilizado = PR_ControlPozo.Id INNER JOIN
                      PR_Paro ON PR_ParoDetalle.IdParo = PR_Paro.Id AND PR_ProdDiariaPozo.Pozo = PR_Paro.Pozo AND PR_ControlPozo.Pozo = PR_Paro.Pozo
END

