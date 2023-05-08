-- ============================================= 
-- Create: DANIEL AC 
-- Updated date: 12/01/2017 
-- Description: AGREGAR IMAGENES PREDETERMINADAS 
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_AgregarImagenesPredeterminadas]  
(
   
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME,
	@Imagen IMAGE,
	@ImagenThumb IMAGE,
	@Detalle NVARCHAR(500)
	
)
AS
BEGIN
	
	INSERT INTO dbo.PV_ImagenPredeterminada
	(	  
	    Detalle,
	    FechaAlta,
	    Imagen,
	    ImagenThumb, 
	    CreadoPor
	)
	VALUES
	(   
	    @Detalle,       -- Detalle - nvarchar(max)
	    GETDATE(), -- FechaAlta - datetime
	    @Imagen,      -- Imagen - image
	    @ImagenThumb,      -- ImagenThumb - image 
	    @IdUsuario          -- CreadoPor - int
	    )

END
