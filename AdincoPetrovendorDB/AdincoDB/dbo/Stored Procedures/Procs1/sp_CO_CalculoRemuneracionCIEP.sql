-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2016
-- Description:	Calculo de remuneracion contrato CIEP
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_CalculoRemuneracionCIEP] 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0, 
	@Mes date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--Insumos
	declare @wts as float
	declare @api as float
	declare @qce as float
	declare @ge as money
	declare @tcero as date
	declare @precioservicios as float
	declare @rt as float
	declare @st as float
	declare @constante_st as float
	declare @pt as float
	declare @ht as float
	declare @at as float
	declare @tarifa as float
	declare @vpqt as float
	declare @vpq as float
	declare @tasadescuento as float
	declare @t as int
	declare @stq as float
	declare @vpstq as float
	declare @delta as float
	declare @gr as float
	declare @vpte as float
	declare @vpteacum as float
	declare @vvpt as float
	declare @vvptacum as float
	declare @precioserviciosanterior as float
	-- Insert statements for procedure here
	--	Wts  (dls/bls)
	select @wts=  precio from CO_PrecioMarcadorMensual PM where IdMarcador= 10000 and mes = @Mes
	--°API, qce (mbce)
	select @qce = qce, @api = api from CO_ProduccionCrudoMensualCIEP where IdContrato = @IdContrato and Mes = @Mes
	--Gastos Elegibles t (mdls) Certificado
	select @ge = geaprobados from CO_GEAceptadosMes where IdContrato = @IdContrato and Mes = @Mes
	--Fecha Efectiva
	select @tcero = iniciovigencia from CO_Contrato where IdContrato = @IdContrato 
	select @t = DATEDIFF ( MONTH , @tcero , @Mes )
	select @tarifa= Tarifa from CO_ConstantesRemuneracionCIEP where anio = year(@mes) and IdContrato=@IdContrato
	--at
	select @at = 0
	--Ht 34 Harcodeado
	select @ht =IIF(@api<34,1,IIF(@api>34,-1,0))
	--VPQ (mpce)
	select @tasadescuento= TasaDescuento from CO_ConstantesRemuneracionCIEP where anio = year(@mes) and IdContrato=@IdContrato	
	select @vpq=   @qce/power( (1+@tasadescuento), @t)
	--VPQt Acumulado (mpce)
	select @vpqt= sum(  P.qce/ power( (1+CR.tasadescuento), DATEDIFF ( MONTH , @tcero , idfecha )))  from AP_Calendario C 
JOIN CO_ProduccionCrudoMensualCIEP P 
on C.IdFecha  = P.mes
JOIN CO_ConstantesRemuneracionCIEP CR
on CR.Anio = year(c.IdFecha ) and CR.idcontrato = P.idcontrato
 where c.idfecha between @tcero  and @mes  and c.dia =1 and P.idcontrato= @idcontrato
	--Pt (dls/bls)
	select @pt = (0.00838*(@api+@ht)+0.68)*@wts+0.1607*(@api+@ht)-7.03+@at
	--St (dls/bls)
	select @constante_st= ConstanteST from CO_ConstantesRemuneracionCIEP where anio = year(@mes) and IdContrato=@IdContrato
	
	select @st = IIF( (@constante_st+0.059*@pt) >   (  0.693*@pt), (  0.693*@pt), (@constante_st+0.059*@pt))
	--Stqt (dls)
	select @stq= @st*@qce

	--VP stqt (mdls)
		select @vpstq=@stq/power((1+@tasadescuento),@t)
	--λt
	Select @delta = 1
	--Gastos Recuperablest (dls)
	select @gr = @ge * @delta
	--VPEt (dls)
	select @vpte = @gr/power((1+@tasadescuento),@t )
	--VPEt Acumulado (dls)
	select @vpteacum= sum( ( GE.GEAprobados * 1)/ power( (1+CR.tasadescuento), DATEDIFF ( MONTH , @tcero , idfecha )))  from AP_Calendario C 
--select * from AP_Calendario C
JOIN CO_GEAceptadosMes GE 
on C.IdFecha  = GE.mes
JOIN CO_ConstantesRemuneracionCIEP CR
on CR.Anio = year(c.IdFecha ) and CR.idcontrato = GE.idcontrato
 where c.idfecha between @tcero  and @Mes  and c.dia =1 and GE.idcontrato= @idcontrato
	
	--VPPt-1 (dls)
	select @precioserviciosanterior = isnull( precio,0) from CO_PrecioServiciosMesCIEP  where idcontrato = @IdContrato  and mes= DATEADD(month,-1, @Mes)
	select  @vvpt =@precioserviciosanterior/power( (1+@tasadescuento),(@t-1))
	--VPPt-1 Acumulado (dls)
	declare @minmes as date 
	select @minmes= min (mes) from CO_PrecioServiciosMesCIEP  where idcontrato = @idcontrato 
	
	select @vvptacum = sum(isnull( isnull( PS.Precio,0 )/ power( (1+CR.tasadescuento), DATEDIFF ( MONTH , @tcero , idfecha )-1),0))  from AP_Calendario C 
JOIN CO_PrecioServiciosMesCIEP PS
on C.IdFecha  = DATEADD(month,1 ,PS.mes)
JOIN CO_ConstantesRemuneracionCIEP CR
on CR.Anio = year(c.IdFecha ) and CR.idcontrato = PS.idcontrato
where c.idfecha between @tcero  and @mes  and c.dia =1 and PS.idcontrato= @IdContrato

	--select @tcero as tc, @minmes, @mes , @vvptacum

	--rt (%)
	
	BEGIN TRY  
   --  Generate divide-by-zero error.  
    SELECT @rt=IIF(((@tarifa*@vpqt+@vpteacum-@vvptacum)/@vpstq)<1 ,((@tarifa*@vpqt+@vpteacum-@vvptacum)/@vpstq), 1 ) 
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		--EXECUTE usp_GetErrorInfo;  
	END CATCH;   
	
	--Precios de los Servicios (mdls)
	select @precioservicios = @qce*@rt*@st


	--Remuneración (simulador)
	SELECT @wts as WTS, @api AS API, @at as AT, @ht as HT, @qce as QCE, @vpq as VPQ, @vpqt as VPQT, @pt as PT, @st as ST, @stq as STQT, 0 as VP, @ge as GE, 0 as LT, @gr as GR, @vpte as VPET, @vpteacum as VPTEA, @rt as RT, @precioservicios as PRECIOSERV, @vvpt as VPPT11, @vvptacum as VTPACUM, @tcero as FE
END
