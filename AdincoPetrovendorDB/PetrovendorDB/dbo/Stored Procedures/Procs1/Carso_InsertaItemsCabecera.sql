DROP PROCEDURE IF EXISTS Carso_InsertaItemsCabecera
GO
-- =============================================  
-- Author:  <Luis David>  
-- Create date: <21/10/2021>  
-- Description: <Se guarda la Cabecera de Carso>  
-- =============================================  
CREATE PROCEDURE  Carso_InsertaItemsCabecera  
	 @FechaEntrega   DATETIME = null,
	 @TipoAdjudicacion  Int,
	 @JustificacionPedido   nvarchar (max) = NULL,
	 @Aprobadores   nvarchar (MAX) = NULL,
	 @MensajeAprobacion   nvarchar (MAX)  = NULL,
	 @IdComparativa   nvarchar (max)  = NULL,
	 @p6   nvarchar (max)  = NULL,
	 @p7   nvarchar (max)  = NULL,
	 @p8   nvarchar (max)  = NULL,
	 @p9   nvarchar (max)  = NULL,
	 @p10   nvarchar (max)  = NULL,
	 @DataAreaID   nvarchar (max)  = NULL,
	 @idAdress nvarchar (max)  = NULL,
	 @hostname nvarchar (max)  = NULL
AS
BEGIN
	insert into Carso_Items_comparativaCabecera
	(
	[FechaEntrega] ,		[TipoAdjudicacion] ,	[JustificacionPedido] ,
	[Aprobadores],			[MensajeAprobacion] ,	[IdComparativa],
	[p6] ,					[p7] ,					[p8] ,
	[p9] ,					[p10],					[DataAreaID],
	CreadoEl,				Activo,					Procesado,
	IpAdress,				Hostname)
	values (
	@FechaEntrega,			@TipoAdjudicacion,		@JustificacionPedido,
	@Aprobadores,			@MensajeAprobacion,		@IdComparativa,
	@p6,					@p7,					@p8,
	@p9,					@p10,					@DataAreaID,
	GETDATE(),				1,						0,
	@idAdress,				@hostname
	)
	select isnull(Max(id),0) as Id from Carso_Items_comparativaCabecera
END