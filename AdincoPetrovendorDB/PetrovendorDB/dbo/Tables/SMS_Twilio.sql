CREATE TABLE [dbo].[SMS_Twilio] (
    [IdTwilio]   INT            IDENTITY (1, 1) NOT NULL,
    [AccountSid] NVARCHAR (100) NOT NULL,
    [AuthToken]  NVARCHAR (100) NOT NULL,
    [Telefono]   NVARCHAR (50)  NOT NULL,
    [Activo]     BIT            NOT NULL,
    CONSTRAINT [PK_MSM_Twilio] PRIMARY KEY CLUSTERED ([IdTwilio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

