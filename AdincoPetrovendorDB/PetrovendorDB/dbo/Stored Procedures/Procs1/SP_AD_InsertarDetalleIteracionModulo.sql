
USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_AD_InsertarDetalleIteracionModulo'
)
	DROP PROCEDURE SP_AD_InsertarDetalleIteracionModulo;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Inserta el detalle de una iteracion y registra el usuario creador.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_InsertarDetalleIteracionModulo] 
	-- Add the parameters for the stored procedure here
	@IdIteracion INT,
	@DescripcionLarga NVARCHAR(MAX),
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.RegistroIteracionesDetalle
	(
	    IdIteracion,
	    DescripcionLarga,
	    FechaRegistro,
	    CreadoPor,
	    IsEliminado
	)
	VALUES
	(   @IdIteracion,         -- IdIteracion - int
	    @DescripcionLarga,       -- DescripcionLarga - nvarchar(max)
	    GETDATE(), -- FechaRegistro - datetime
	    @IdUsuario,
	    0       -- IsEliminado - bit
	    )
END

