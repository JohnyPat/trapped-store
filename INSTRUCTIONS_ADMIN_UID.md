# Admin UID Setup Instructions

## Required First Step: Set `adminUid` in Firebase

The admin authentication system reads the `adminUid` from the Realtime Database `settings` node. This must be configured before admin login will work.

### Option 1: Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **trapped-56f3e**
3. Navigate to **Project Settings** (gear icon → Project settings)
4. Scroll to **Your apps** section
5. For each app (iOS/Android/Web), note the configuration
6. **OR** go to **Realtime Database** in the left navigation

### Option 2: Set via Realtime Database

1. In Firebase Console, go to **Realtime Database**
2. Select your database instance (`trapped-56f3e-default-rtdb`)
3. Go to the **rules** tab or **Data** tab
4. Navigate to the `settings` path (create it if it doesn't exist)
5. Add the `adminUid` field with the admin user's UID value

### Option 3: Using Firebase CLI

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login and select project
firebase login
firebase use trapped-56f3e

# Set adminUid in Realtime Database settings
firebase database:patch --data '{"adminUid": "YOUR_ADMIN_UID_HERE"}' https://trapped-56f3e-default-rtdb.firebaseio.com/settings
```

### Getting the Admin UID

1. In Firebase Console → **Authentication** → **Users**
2. Find the user account that should have admin privileges
3. Copy their **UID** (looks like: `FazJRuoaaaB...`)
4. Set this as the `adminUid` value in `settings`

### Database Structure After Setup

Your Realtime Database should have:

```
{
  "settings": {
    "adminUid": "FazJRuoaaaB...-admin-account-uid"
  },
  "users": { ... },
  "products": { ... },
  "categories": { ... },
  "orders": { ... }
}
```

### Security Rules Update

Ensure your Firebase Security Rules allow the admin to write:

```javascript
service cloud.database {
  match /databases/{database}/rules {
    
    match /settings/{document} {
      allow read: if true;  // Read access for checking admin status
      allow write: if request.auth.uid == data.val().adminUid;
    }
    
    // Admin CRUD operations
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth.uid == request.resource.data.adminUid 
                   || request.auth.token.admin == true;
    }
    // ... similar for categories, orders, users
  }
}
```

### After Setting adminUid

1. Restart your Flutter app
2. Use an email/password account that matches the `adminUid` 
3. Login as admin and access the full dashboard
4. Regular customers attempting admin routes will be denied with: "Your account does not have admin privileges."

### Test Credentials

Once `adminUid` is set, you can create an admin account:
- **Email**: any email you use to sign up via Firebase Auth
- **Password**: any password you set during sign-up
- **Expected**: Successful login → Admin Dashboard

---