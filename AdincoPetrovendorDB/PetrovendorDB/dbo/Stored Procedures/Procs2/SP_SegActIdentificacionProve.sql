
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-01-17
-- Description:	
-- =============================================
-- =============================================
-- Modificado por:		Pedro Acuña
-- Update date: 22/08/2017
-- Description:	Se agregan los campos CURP,RPPC, GIRO, MonedaFacturar,IMSS,Telefono
-- =============================================
--**************************************************************
-- Modified:      <Jose Roman>									
-- Updated date: <09/01/2018>									
-- Description: <Se agrega el guardado de Verificable y parametros de contrato>
--**************************************************************
--**************************************************************
-- Modified:      <Daniel AC>									
-- Updated date: <01/02/2018>									
-- Description: <Se agrega variable IdProveedor>
--**************************************************************

CREATE PROCEDURE [dbo].[SP_SegActIdentificacionProve]
    -- Add the parameters for the stored procedure here
    @IdUsuario INT,
    @RazonSocial NVARCHAR(100),
    @RegimenCapital NVARCHAR(100),
    @FechaConstitucion NVARCHAR(50),
    @FechaOperaciones NVARCHAR(50),
    @FechaCambioSituacion NVARCHAR(50),
    @CURP NVARCHAR(20),
    @RPPC NVARCHAR(50),
    @Giro NVARCHAR(100),
    @MonedaFacturar INT,
    @IMSS NVARCHAR(50),
    @Telefono NVARCHAR(20),
    @idNacionalidad INT,
    @idTipoRegimen INT,
    @SituacionContribuyente NVARCHAR(15),
    @AnteriorInhabilitadoSFP INT,
    @InhabilitadoSFP INT,
    @FechaFinalizacionSancionSFP NVARCHAR(50),
    @IdRegimenCapital INT,
	@Alias NVARCHAR(200),
	@Verificable BIT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    --@IdUsuario     INT = null,
    @FechaRegistro DATETIME = NULL,
	@IdProveedor INT 
  /*---------------------------------------------------------------*/ 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    UPDATE dbo.S_Proveedor
    SET RazonSocial = @RazonSocial,
        RegimenCapital = @RegimenCapital,
        FechaConstitucion = @FechaConstitucion,
        FechaOperacion = @FechaOperaciones,
        FechaCambioSituacion = @FechaCambioSituacion,
        CURP = @CURP,
        RPPC = @RPPC,
        Giro = @Giro,
        MonedaFacturar = @MonedaFacturar,
        IMSS = @IMSS,
        Telefono = @Telefono,
        IdNacionalidad = @idNacionalidad,
        IdTipoRegimen = @idTipoRegimen,
        SituacionContribuyente = @SituacionContribuyente,
        AnteriorInhabilitadoSFP = @AnteriorInhabilitadoSFP,
        InhabilitadoSFP = @InhabilitadoSFP,
        FechaFinalizacionSancionSFP = @FechaFinalizacionSancionSFP,
        IdRegimenCapital = @IdRegimenCapital,
		Alias = @Alias,
		Verificable = @Verificable
    FROM S_Proveedor P
        JOIN S_UsuarioProveedor UP
            ON UP.IdProveedor = P.IdProveedor
        JOIN S_Usuario U
            ON UP.IdUsuario = U.IdUsuario
    WHERE U.IdUsuario = @IdUsuario AND P.IdProveedor=@IdProveedor


    SELECT CONCAT('Sus datos', @IdUsuario, ' han sido actualizados') AS Mensaje

END

