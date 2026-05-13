CREATE PROCEDURE   [dbo].[sp_PR_Actualizar_control_prod_max] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
-- Obtener la fecha del ultimo control valido.	
SELECT     MAX(HoraFin ) AS Fecha, Pozo
INTO  [#maxpozo]
FROM         PR_ControlPozo
GROUP BY Pozo
 
Alter table [#maxpozo] add idcontrol int 


update #maxpozo set #maxpozo.idcontrol = PR_ControlPozo.Id  from PR_ControlPozo where #maxpozo.Fecha= PR_ControlPozo.HoraFin  and #maxpozo.Pozo= PR_ControlPozo.Pozo 

update PR_ControlPozo set Valido = 1 FROM #maxpozo WHERE PR_ControlPozo.Id = #maxpozo.idcontrol

UPDATE PR_Pozo SET UltimoControlValido =  #maxpozo.idcontrol from #maxpozo where PR_Pozo.Id = #maxpozo.pozo 

UPDATE PR_Pozo set ProduccionBruta = PR_ControlPozo.ProduccionBruta , ProduccionNeta = PR_ControlPozo.ProduccionNeta ,PorcentajeAgua = PR_ControlPozo.pctAgua from PR_ControlPozo  where PR_Pozo.UltimoControlValido  = PR_ControlPozo.Id    

UPDATE PR_Pozo set UltimoControl= PR_ControlPozo.HoraFin  from PR_ControlPozo  where PR_Pozo.UltimoControlValido  = PR_ControlPozo.Id    


DROP table  #maxpozo  
	
END

