CREATE  PROCEDURE [dbo].[SP_Ax_WsCarso_BitacoraAcceso]
    -- Add the parameters for the stored procedure here

    @DataAreaID NVARCHAR(500),
	@Accion NVARCHAR(500),
	@Error INT,
	@Observacion NVARCHAR(MAX),
	@IdComparativa NVARCHAR(500),
	@IdBitacora INT,
	@IpAddress NVARCHAR(500),
	@HostName NVARCHAR(500)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	IF @Accion='ABRIR'
	BEGIN 
		INSERT dbo.AX_Bitacora
		(
		    DataAreaId,
		    FechaAcceso,
		    Observacion,
		    IdComparativa,
			IpAddress,
			HostName
		)
		VALUES
		(   @DataAreaID,       -- DataAreaId - nvarchar(500)
		    GETDATE(), -- FechaAcceso - datetime	   
		    N'',       -- Observacion - nvarchar(max)
		    @IdComparativa,        -- IdComparativa - nvarchar(500)
			@IpAddress,
			@HostName
		 ) 

		 SELECT 'SUCCESS', @@IDENTITY
	END 

	IF @Accion='CERRAR'
	BEGIN 
		UPDATE dbo.AX_Bitacora
		SET FechaSalida= GETDATE(),
		Error=@Error,
		Observacion=@Observacion
		WHERE IdBitacora=@IdBitacora

		SELECT 'SUCCESS', @IdBitacora
	END 

	IF @Accion='ERROR'
	BEGIN 
		INSERT dbo.AX_Bitacora
		(
		    DataAreaId,
		    FechaAcceso,
		    Observacion,
		    IdComparativa,
			FechaSalida,
			Error,
			HostName,
			IpAddress
		)
		VALUES
		(   @DataAreaId,       -- DataAreaId - nvarchar(500)
		    GETDATE(), -- FechaAcceso - datetime	  
			@Observacion,		    
		    @IdComparativa,       -- IdComparativa - nvarchar(500)
			GETDATE(),
			@Error	,
			@HostName,
			@IpAddress	
		 ) 

		 SELECT 'SUCCESS', @@IDENTITY
	END 
   

END;
