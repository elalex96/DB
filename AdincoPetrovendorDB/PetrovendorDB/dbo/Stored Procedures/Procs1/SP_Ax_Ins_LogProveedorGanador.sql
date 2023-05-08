-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Ax_Ins_LogProveedorGanador] 
	-- Add the parameters for the stored procedure here
@Cur  varchar(MAX) ,
@Itm  varchar(MAX), 
@Obs  varchar(MAX), 
@Qty  FLOAT,
@Pri FLOAT,
@Rec BIGINT,
@Uni  varchar(MAX) ,
@RFC  varchar(MAX) ,
@Dat  varchar(MAX) ,
@Ped  varchar(MAX) ,
@OCI  varchar(MAX) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO dbo.AX_BitacoraProveedorGanador
(
    Currency,
    ItemId,
    Observations,
    Qty,
    Price,
    RecID,
    Unit,
    RFC,
    DataAreaID,
    PedidoADINCO,
    OCIIFormat,
    FechaRegistro
)
VALUES
(   @Cur,       -- Currency - varchar(max)
    @Itm,       -- ItemId - varchar(max)
    @Obs,       -- Observations - varchar(max)
    @Qty,      -- Qty - float
    @Pri,      -- Price - float
    @Rec,        -- RecID - bigint
    @Uni,       -- Unit - varchar(max)
    @RFC,       -- RFC - varchar(max)
    @Dat,       -- DataAreaID - varchar(max)
    @Ped,       -- PedidoADINCO - varchar(max)
    @OCI,       -- OCIIFormat - varchar(max)
    GETDATE() -- FechaRegistro - datetime
    )
    -- Insert statements for procedure here
	SELECT 'true'	

 
END
