/****** Object:  StoredProcedure [dbo].[Resumen]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE PROCEDURE  [dbo].[sp_PR_Resumen]
	
AS
BEGIN
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
Select  313 as Total_Pozos_Base,	5  as Total_Pozos_Incrementales,	8696.02296344 as Produccion_Bruta_Base,	7096.46189821  as Produccion_Neta_Base,	310.26999665 as Produccion_Bruta_Incremental,	303.97397995 as Produccion_Neta_Incremental,	9006.29296009	as Produccion_Bruta_Total, 7400.43587816 as Produccion_Neta_Total, 	'Marzo' As Mes,	3 as Mes_


SELECT   1 as contador,    Pozo, Fecha into #pozos 
FROM            PR_ProdDiariaPozo 
WHERE   (     (Fecha = '20130228') OR
                         (Fecha = '20130331') OR
                         (Fecha = '20130430') OR
                         (Fecha = '20130531') OR
                         (Fecha = '20130630') OR
                         (Fecha = '20130731') OR
                         (Fecha = '20130831') OR
                         (Fecha = '20130930') OR
                         (Fecha = '20131031') OR
                         (Fecha = '20131130')
						  OR
                         (Fecha = '20131231')) and PR_ProdDiariaPozo.Estado  = 9 


set language spanish		 
select  sum(  case PR_Pozo.TipoProduccion when 133 then 1 else 0 end) as  Total_Pozos_Base 
		,sum(  case PR_Pozo.TipoProduccion when 134 then 1 else 0 end) as Total_Pozos_Incrementales 
		,sum(  case  PR_Pozo.TipoProduccion  when 133 then PR_ControlPozo.ProduccionBruta   else 0 end) as Produccion_Bruta_Base 
		,sum(  case  PR_Pozo.TipoProduccion  when 133 then PR_ControlPozo.ProduccionNeta    else 0 end) as Produccion_Neta_Base 
		,sum(  case  PR_Pozo.TipoProduccion  when 134 then PR_ControlPozo.ProduccionBruta   else 0 end) as Produccion_Bruta_Incremental
		,sum(  case  PR_Pozo.TipoProduccion  when 134 then PR_ControlPozo.ProduccionNeta    else 0 end) as Produccion_Neta_Incremental
		,sum(  PR_ControlPozo.ProduccionBruta   ) as Produccion_Bruta_Total
		,sum(  PR_ControlPozo.ProduccionNeta  ) as Produccion_Neta_Total
		,DATENAME (month,#pozos.Fecha) as Mes  , month(#pozos.Fecha) as Mes_   from #pozos  
	join PR_Pozo 
		on PR_Pozo.id = #pozos.Pozo
	join PR_ControlPozo  
		on PR_Pozo.UltimoControlValido  =PR_ControlPozo.Id  
group by  DATENAME (month,#pozos.Fecha), month(#pozos.Fecha)  order by month(#pozos.Fecha) 
END

