
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 28/01/198
-- Description:
-- =============================================
CREATE  PROCEDURE [dbo].[Scoc_InsertaFirmaCer]
	@Mes DATE,
	@idUsuario int,
	@idContrato INT,
     @IdPermiso int ,
     @RFC varchar(30),
     @RazonSocial varchar(300),
     @FechaVigencia datetime,
	 @FechaCaducidad datetime,
     @Emisor varchar(300),
     @SignatureAlgorithm varchar(500),
     @SerialNumber varchar(500),
	 @Comentarios VARCHAR(500)
    
AS
BEGIN
DECLARE @error NVARCHAR(Max);

	SET NOCOUNT ON;
	INSERT INTO dbo.SCOC_FirmaElectronica (IdContrato,
	                                       MesReporte,
	                                       IdPermiso,
	                                       RFC,
	                                       RazonSocial,
	                                       FechaVigencia,
										   FechaCaducidad,
	                                       Emisor,
	                                       SignatureAlgorithm,
	                                       SerialNumber,
	                                       Comentarios,
	                                       FecMovto,
	                                       UsuarioID)
	VALUES (@idContrato, -- IdContrato - int
	        @Mes, -- MesReporte - date
	       @IdPermiso, -- IdPermiso - int
	        @RFC, -- RFC - varchar(30)
	        @RazonSocial, -- RazonSocial - varchar(300)
	        @FechaVigencia, -- FechaVigencia - datetime
			@FechaCaducidad,
	        @Emisor, -- Emisor - varchar(300)
	        @SignatureAlgorithm, -- SignatureAlgorithm - varchar(500)
	        @SerialNumber, -- SerialNumber - varchar(500)
	        @Comentarios, -- Comentarios - varchar(500)
	        GETDATE(), -- FecMovto - datetime
	        @idUsuario -- UsuarioID - int
	    )
		SET @error='';
		SELECT @error AS 'Error';
	END