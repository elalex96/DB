-- =============================================
-- Author:	Reyna Olvera
-- Create date: 23/02/18
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CO_GraficaNominacion]
	-- Add the parameters for the stored procedure here
@fechaMesDiaAño date,
@hidrocarburo int,
@PuntoEntrega int,
@idContrato int,
@idUsuario int=0
 
AS
BEGIN

	SET NOCOUNT ON;

   
	
Declare 

@mes int,
@anio int;
SET LANGUAGE Spanish;
--*********EXTRAE EL MES Y AÑO DE LA FECHA *********

	Select @mes= Month(@fechaMesDiaAño);
	Select @anio= Year(@fechaMesDiaAño);

	
IF OBJECT_ID('tempdb..#PruebaNominacion') IS NOT NULL
				Drop table #PruebaNominacion;
IF OBJECT_ID('tempdb..#pruebaDiario') IS NOT NULL
				Drop table #pruebaDiario;

--*********COMIENZA A BUSCAR LOS DATOS PARA LA GRAFICA Y EL VOLUMEN PROGRAMADO MENSUAL SE  CALCULA SU MAS Y MENOS PORCIENTO(4%)*********
Select
idFecha,
--day(NM.IDfecha)+ DATENAME(MONTH, NM.IDfecha) +year(NM.IDfecha) as Fecha,
CONCAT(Day(NM.idFecha),' ',datename(month, NM.IdFecha), ' ', YEAR(NM.IdFecha)) AS Fecha,
Nombre+'  ('+Abreviatura+')' as Titulo_yAxis,
'Producción diaria'+'  ('+Abreviatura+')' as titulo,
'Real' as nameSerieDiario,
'Mensual' as nameSerieMensual,
'Más 4%' as nameSeriePorcientoMas,
'Menos 4%' as nameSeriePorcientoMenos,
NM.volumenProgramado  as VolumenProgramadoMensual,
NM.VolumenProgramado-((NM.VolumenProgramado*4)/100) as VolumenProgramadoMenosPorciento,
NM.VolumenProgramado+((NM.VolumenProgramado*4)/100) as VolumenProgramadoMasPorciento
into #PruebaNominacion
	  From CO_NominacionVolumen   NM
	  Join CO_UnidadMedida UM on NM.idUnidadMedida= UM.idUnidadMedida
	  where Month(NM.idFecha)=@mes 
	  and Year(NM.idFecha)=@anio
	  and NM.idContrato=@idContrato
	  and NM.puntoEntregaId=@PuntoEntrega
	  and NM.idProductoNominacion= @hidrocarburo
	 --Select * from #PruebaNominacion
	
--*********EXTRAEN LOS DATOS DE VOLUMEN DIARIO PARA MOSTRAR EN LA GRAFICA*********
	Select idFecha,volumenProgramado as VolumenProgramadoDiario
	Into #pruebaDiario
	From CO_NominacionDiaria
	 where Month(idFecha)=@mes 
	  and Year(idFecha)=@anio
	  and idContrato=@idContrato
	  and puntoEntregaId=@PuntoEntrega
	  and idProductoNominacion= @hidrocarburo
	 -- Select * from  #pruebaDiario

	  --Select * 
	  --from 
	  --#PruebaNominacion PN
	  --Left Join #pruebaDiario PD on PN.idFecha= PD.idFecha

	 
--*********SE SELECCIONAN LOS DATOS PARA LA GRAFICA Y  SI ALGUN VOLUMEN DIARIO ESTA EN NULL,*********
--*********SERA MOSTRADO EN SU LUGAR EL VOLUMEN MENSUAL PARA QUE EN LA GRAFICA ESA SERIE SE MUESTRE TRAS LA MENSUAL*********
		SELECT 
		PN.idFecha,Fecha,
		Titulo_yAxis,
		titulo,
		nameSerieDiario,
		nameSerieMensual,
		nameSeriePorcientoMas,
		nameSeriePorcientoMenos,
		VolumenProgramadoMensual,
		VolumenProgramadoMenosPorciento,
		VolumenProgramadoMasPorciento, 
			CASE WHEN pd.VolumenProgramadoDiario IS NULL 
			THEN pn.VolumenProgramadoMensual
			ELSE pd.VolumenProgramadoDiario
			END 
			AS VolumenProgramadoDiario
				FROM
				 #PruebaNominacion PN
				 Left Join #pruebaDiario PD on PN.idFecha= PD.idFecha

	  

END

