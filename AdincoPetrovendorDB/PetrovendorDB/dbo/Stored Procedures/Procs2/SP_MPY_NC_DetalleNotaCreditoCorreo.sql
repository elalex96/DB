

create  PROCEDURE [dbo].[SP_MPY_NC_DetalleNotaCreditoCorreo]  
    @IdProveedor INT,
    @IdNotaCredito INT,
    @IdOperacion INT

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;	      

		select IdOperacion = 0,--0          
           IdPedido = ap.IdPedido,--1
           AP.IdAceptacionPedido,--2
           IdAceptacionNotaCredito = anc.IdAceptacionNotaCredito,--3
           IdSolicitudPedido = 0,--4
		   E.Nombre
		from MPY_MM_AceptacionNotaCredito anc
		inner join MPY_MM_AceptacionPedido ap on ap.IdAceptacionPedido = anc.IdAceptacionPedido		
		inner join TA_Estatus e on e.IdEstatus = anc.IdEstatus
		where anc.IdAceptacionNotaCredito = @IdNotaCredito


END;



